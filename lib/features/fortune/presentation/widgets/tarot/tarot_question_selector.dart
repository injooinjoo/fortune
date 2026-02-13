import 'package:flutter/material.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/design_system/design_system.dart';

class TarotQuestionSelector extends StatefulWidget {
  final Function(String) onQuestionSelected;
  final Function(String) onCustomQuestionChanged;
  final VoidCallback onStartReading;
  final String? selectedQuestion;
  final String? customQuestion;

  const TarotQuestionSelector({
    super.key,
    required this.onQuestionSelected,
    required this.onCustomQuestionChanged,
    required this.onStartReading,
    this.selectedQuestion,
    this.customQuestion,
  });

  @override
  State<TarotQuestionSelector> createState() => _TarotQuestionSelectorState();
}

class _TarotQuestionSelectorState extends State<TarotQuestionSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _customController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 템플릿 질문들
  static const List<Map<String, dynamic>> _templateQuestions = [
    {
      'question': '언제 돈이 들어올까요?',
      'icon': Icons.attach_money,
      'color': DSColors.warning,
    },
    {
      'question': '연애운은 어떨까요?',
      'icon': Icons.favorite,
      'color': DSColors.accentSecondary,
    },
    {
      'question': '취업이 언제 될까요?',
      'icon': Icons.work,
      'color': DSColors.accentSecondary,
    },
    {
      'question': '건강은 어떨까요?',
      'icon': Icons.favorite_border,
      'color': DSColors.success,
    },
    {
      'question': '새로운 기회가 올까요?',
      'icon': Icons.auto_awesome,
      'color': DSColors.accentSecondary,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // 기존 커스텀 질문이 있으면 텍스트 필드에 설정
    if (widget.customQuestion != null) {
      _customController.text = widget.customQuestion!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🟠 TarotQuestionSelector build - selectedQuestion: ${widget.selectedQuestion}');
    final isDark = context.isDark;
    final colors = context.colors;
    final typography = context.typography;
    final hasSelection = widget.selectedQuestion != null ||
        (widget.customQuestion?.isNotEmpty == true);
    final hasCustomInput = widget.customQuestion?.isNotEmpty == true;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          children: [
            // 스크롤 가능한 컨텐츠
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 100, // FloatingBottomButton을 위한 공간
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    '어떤 것이 궁금하신가요?',
                    style: typography.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: DSSpacing.sm),

                  // 부제목
                  Text(
                    '카드가 답해드릴게요',
                    style: typography.labelLarge.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 템플릿 질문들
                  ...List.generate(_templateQuestions.length, (index) {
                    final question = _templateQuestions[index];
                    final isSelected =
                        widget.selectedQuestion == question['question'];
                    debugPrint(
                        '🔶 Question "${question['question']}" - isSelected: $isSelected');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuestionCard(
                        question: question['question'] as String,
                        icon: question['icon'] as IconData,
                        color: question['color'] as Color,
                        isSelected: isSelected,
                        isDark: isDark,
                        onTap: () {
                          debugPrint(
                              '🔵 Question tapped: ${question['question']}');
                          _focusNode.unfocus();
                          widget.onQuestionSelected(
                              question['question'] as String);
                          debugPrint(
                              '🔵 onQuestionSelected called with: ${question['question']}');
                          // 템플릿 질문을 선택하면 커스텀 입력 완전히 초기화
                          _customController.clear();
                          // widget.onCustomQuestionChanged(''); // 제거 - 이게 _selectedQuestion을 null로 만듦
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: DSSpacing.lg),

                  // 직접 입력 섹션
                  Text(
                    '직접 입력하기',
                    style: typography.headingSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: DSSpacing.md),

                  // 직접 입력 텍스트 필드
                  Container(
                    decoration: BoxDecoration(
                      color: hasCustomInput
                          ? DSColors.accent.withValues(alpha: 0.05)
                          : colors.surfaceSecondary,
                      border: Border.all(
                        color: hasCustomInput || _focusNode.hasFocus
                            ? DSColors.accent
                            : colors.border,
                        width: hasCustomInput || _focusNode.hasFocus ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      boxShadow: hasCustomInput
                          ? [
                              BoxShadow(
                                color: DSColors.accent.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: _customController,
                      focusNode: _focusNode,
                      maxLines: 3,
                      maxLength: 100,
                      onChanged: (value) {
                        widget.onCustomQuestionChanged(value);
                        // 커스텀 질문을 입력하면 템플릿 선택 해제
                        if (value.isNotEmpty &&
                            widget.selectedQuestion != null) {
                          widget.onQuestionSelected('');
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            '궁금한 것을 자유롭게 입력해주세요\n예: 새로운 직장에서 잘 적응할 수 있을까요?',
                        hintStyle: TextStyle(
                          color: colors.textTertiary,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(DSSpacing.md),
                        counterText: '',
                      ),
                      style: typography.labelLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FloatingBottomButton
            UnifiedButton.floating(
              text: '운세 보기',
              onPressed: hasSelection ? widget.onStartReading : null,
              isEnabled: hasSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String question,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : colors.surface,
          border: Border.all(
            color: isSelected ? color : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadius.md),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : color.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 20,
                  ),
                ),

                const SizedBox(width: DSSpacing.md),

                // 질문 텍스트
                Expanded(
                  child: Text(
                    question,
                    style: typography.labelLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? color : colors.textPrimary,
                    ),
                  ),
                ),

                // 선택 표시
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
