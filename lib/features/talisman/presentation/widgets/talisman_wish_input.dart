import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/components/toss_button.dart';

class TalismanWishInput extends StatefulWidget {
  final TalismanCategory selectedCategory;
  final Function(String) onWishSubmitted;

  const TalismanWishInput({
    super.key,
    required this.selectedCategory,
    required this.onWishSubmitted,
  });

  @override
  State<TalismanWishInput> createState() => _TalismanWishInputState();
}

class _TalismanWishInputState extends State<TalismanWishInput> {
  final TextEditingController _wishController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _wishController.addListener(_validateInput);
    
    // Auto focus after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _wishController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValid = _wishController.text.trim().length >= 5;
    });
  }

  String get _placeholderText {
    switch (widget.selectedCategory) {
      case TalismanCategory.wealth:
        return '예: 이번 달 매출 목표 달성하기';
      case TalismanCategory.love:
        return '예: 좋은 사람과 의미있는 만남 갖기';
      case TalismanCategory.career:
        return '예: 승진 기회 얻기';
      case TalismanCategory.health:
        return '예: 건강한 생활 습관 만들기';
      case TalismanCategory.study:
        return '예: 자격증 시험 합격하기';
      case TalismanCategory.relationship:
        return '예: 동료들과 원만한 관계 유지하기';
      case TalismanCategory.goal:
        return '예: 새로운 취미 시작하기';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Category Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TossTheme.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.selectedCategory.emoji,
                style: TypographyUnified.heading3,
              ),
              SizedBox(width: 12),
              Text(
                widget.selectedCategory.displayName,
                style: TossTheme.body2.copyWith(
                  color: TossTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms)
          .slideX(begin: -0.2, end: 0),
        
        SizedBox(height: 32),
        
        // Input Title
        Text(
          '구체적으로 어떤 소원인가요?',
          style: TossTheme.heading3.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ).animate(delay: 100.ms)
          .fadeIn(duration: 400.ms),
        
        SizedBox(height: 8),
        
        Text(
          '구체적이고 명확할수록 더욱 효과적인 부적을 만들어드려요',
          style: TossTheme.subtitle2.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ).animate(delay: 150.ms)
          .fadeIn(duration: 400.ms),
        
        const SizedBox(height: 24),
        
        // Text Input
        TextFormField(
          controller: _wishController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: _placeholderText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: '${_wishController.text.length}/100',
          ),
          maxLines: 3,
          maxLength: 100,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _isValid ? (value) => _handleSubmit() : null,
        ).animate(delay: 200.ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0),
        
        const SizedBox(height: 8),
        
        // Input Tip
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            ),
            SizedBox(width: 4),
            Text(
              '최소 5자 이상 입력해주세요',
              style: TossTheme.caption.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
              ),
            ),
          ],
        ).animate(delay: 250.ms)
          .fadeIn(duration: 400.ms),
        
        const SizedBox(height: 40),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: TossButton(
            text: '부적 만들기',
            onPressed: _isValid ? _handleSubmit : null,
            size: TossButtonSize.large,
          ),
        ).animate(delay: 300.ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  void _handleSubmit() {
    final wish = _wishController.text.trim();
    if (wish.length >= 5) {
      widget.onWishSubmitted(wish);
    }
  }
}