import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/services/talisman_generation_service.dart' as ai_talisman;
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/voice_input_text_field.dart';

class TalismanWishInput extends StatefulWidget {
  final TalismanCategory selectedCategory;
  final Function(String) onWishSubmitted;
  final Function(String wish, bool isAI, String? imageUrl)? onAIWishSubmitted; // AI 생성용 콜백
  final Function(bool isValid, bool isLoading)? onValidationChanged;

  const TalismanWishInput({
    super.key,
    required this.selectedCategory,
    required this.onWishSubmitted,
    this.onAIWishSubmitted,
    this.onValidationChanged,
  });

  @override
  State<TalismanWishInput> createState() => TalismanWishInputState();
}

class TalismanWishInputState extends State<TalismanWishInput> {
  final TextEditingController _wishController = TextEditingController();
  bool _isValid = false;
  bool _isGeneratingAI = false;

  /// Public getter for wish text
  String get wishText => _wishController.text.trim();

  /// Public getter for valid state
  bool get isValid => _isValid;

  /// Public getter for loading state
  bool get isGeneratingAI => _isGeneratingAI;

  @override
  void initState() {
    super.initState();
    _wishController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _wishController.removeListener(_validateInput);
    _wishController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final newIsValid = _wishController.text.trim().length >= 5;
    if (_isValid != newIsValid) {
      setState(() {
        _isValid = newIsValid;
      });
      widget.onValidationChanged?.call(_isValid, _isGeneratingAI);
    }
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
                style: context.heading3,
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

        // Voice Input
        VoiceInputTextField(
          controller: _wishController,
          onSubmit: _isValid ? (text) => handleAISubmit() : (text) {},
          hintText: _placeholderText,
          transcribingText: '듣고 있어요...',
        ).animate(delay: 200.ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0),

        const SizedBox(height: 8),

        // Input Tip & Character Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            ),
            Text(
              '${_wishController.text.length}/100',
              style: TossTheme.caption.copyWith(
                color: _wishController.text.length >= 5
                    ? TossDesignSystem.successGreen
                    : (isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight),
              ),
            ),
          ],
        ).animate(delay: 250.ms)
          .fadeIn(duration: 400.ms),
        
        // 하단 플로팅 버튼을 위한 여백
        const SizedBox(height: 100),
      ],
    );
  }

  /// Public method to trigger AI submit (called from parent)
  Future<void> handleAISubmit() async {
    final wish = _wishController.text.trim();
    if (wish.length < 5) return;

    setState(() => _isGeneratingAI = true);
    widget.onValidationChanged?.call(_isValid, _isGeneratingAI);

    try {
      final talismanService = ai_talisman.TalismanGenerationService();

      // Map TalismanCategory to TalismanGenerationService category
      final aiCategory = _mapToAICategory(widget.selectedCategory);

      Logger.info('[TalismanWishInput] Generating AI talisman for category: ${aiCategory.displayName}');

      // Generate AI talisman image
      final result = await talismanService.generateTalisman(
        category: aiCategory,
      );

      Logger.info('[TalismanWishInput] AI talisman generated: ${result.imageUrl}');

      if (mounted) {
        // Call parent callback with AI-generated result including image URL
        widget.onAIWishSubmitted?.call(wish, true, result.imageUrl);
      }
    } catch (e, stackTrace) {
      Logger.error('[TalismanWishInput] Failed to generate AI talisman: $e', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('신령 부적 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAI = false);
        widget.onValidationChanged?.call(_isValid, _isGeneratingAI);
      }
    }
  }

  // Map TalismanCategory to TalismanGenerationService category
  ai_talisman.TalismanCategory _mapToAICategory(TalismanCategory category) {
    switch (category) {
      case TalismanCategory.health:
        return ai_talisman.TalismanCategory.diseasePrevention;
      case TalismanCategory.love:
        return ai_talisman.TalismanCategory.loveRelationship;
      case TalismanCategory.wealth:
      case TalismanCategory.career:
        return ai_talisman.TalismanCategory.wealthCareer;
      case TalismanCategory.goal:
        return ai_talisman.TalismanCategory.homeProtection;
      case TalismanCategory.study:
        return ai_talisman.TalismanCategory.academicSuccess;
      case TalismanCategory.relationship:
        return ai_talisman.TalismanCategory.homeProtection;
    }
  }
}