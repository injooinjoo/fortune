import 'package:flutter/material.dart';
import '../../../../../shared/components/toss_button.dart';

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
      'color': Color(0xFF10B981),
    },
    {
      'question': '연애운은 어떨까요?',
      'icon': Icons.favorite,
      'color': Color(0xFFEC4899),
    },
    {
      'question': '오늘의 전체 운세는?',
      'icon': Icons.star,
      'color': Color(0xFF7C3AED),
    },
    {
      'question': '취업이 언제 될까요?',
      'icon': Icons.work,
      'color': Color(0xFF3B82F6),
    },
    {
      'question': '건강은 어떨까요?',
      'icon': Icons.favorite_border,
      'color': Color(0xFFF59E0B),
    },
    {
      'question': '새로운 기회가 올까요?',
      'icon': Icons.auto_awesome,
      'color': Color(0xFF8B5CF6),
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
    final hasSelection = widget.selectedQuestion != null || 
                        (widget.customQuestion?.isNotEmpty == true);
    final hasCustomInput = widget.customQuestion?.isNotEmpty == true;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 제목
              const Text(
                '어떤 것이 궁금하신가요?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 부제목
              const Text(
                '카드가 답해드릴게요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8B95A1),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 템플릿 질문들
              ...List.generate(_templateQuestions.length, (index) {
                final question = _templateQuestions[index];
                final isSelected = widget.selectedQuestion == question['question'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildQuestionCard(
                    question: question['question'] as String,
                    icon: question['icon'] as IconData,
                    color: question['color'] as Color,
                    isSelected: isSelected,
                    onTap: () {
                      _focusNode.unfocus();
                      widget.onQuestionSelected(question['question'] as String);
                      // 템플릿 질문을 선택하면 커스텀 입력 완전히 초기화
                      _customController.clear();
                      widget.onCustomQuestionChanged('');
                    },
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // 직접 입력 섹션
              const Text(
                '직접 입력하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191919),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 직접 입력 텍스트 필드
              Container(
                decoration: BoxDecoration(
                  color: hasCustomInput 
                      ? const Color(0xFF3182F6).withOpacity(0.05)
                      : Colors.white,
                  border: Border.all(
                    color: hasCustomInput || _focusNode.hasFocus 
                        ? const Color(0xFF3182F6)
                        : const Color(0xFFE5E7EB),
                    width: hasCustomInput || _focusNode.hasFocus ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: hasCustomInput
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3182F6).withOpacity(0.1),
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
                    if (value.isNotEmpty && widget.selectedQuestion != null) {
                      widget.onQuestionSelected('');
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: '궁금한 것을 자유롭게 입력해주세요\n예: 새로운 직장에서 잘 적응할 수 있을까요?',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF191919),
                    height: 1.4,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 운세 보기 버튼
              SizedBox(
                width: double.infinity,
                child: TossButton(
                  text: '운세 보기',
                  onPressed: hasSelection ? widget.onStartReading : null,
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.large,
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected 
                ? color
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? color
                    : color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 질문 텍스트
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? color
                      : const Color(0xFF191919),
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
    );
  }
}