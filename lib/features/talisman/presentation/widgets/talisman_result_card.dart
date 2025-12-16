import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_design.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';

class TalismanResultCard extends StatefulWidget {
  final TalismanDesign talismanDesign;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onSetWallpaper;

  const TalismanResultCard({
    super.key,
    required this.talismanDesign,
    this.onSave,
    this.onShare,
    this.onSetWallpaper,
  });

  @override
  State<TalismanResultCard> createState() => _TalismanResultCardState();
}

class _TalismanResultCardState extends State<TalismanResultCard> {
  bool _isSaved = false;

  // ✅ GPT 스타일 타이핑 효과
  int _currentTypingSection = 0;

  Color get _categoryColor {
    switch (widget.talismanDesign.category) {
      case TalismanCategory.wealth:
        return const Color(0xFFFFD700);
      case TalismanCategory.love:
        return const Color(0xFFFF6B9D);
      case TalismanCategory.career:
        return const Color(0xFF4A90E2);
      case TalismanCategory.health:
        return const Color(0xFF7ED321);
      case TalismanCategory.study:
        return const Color(0xFF9013FE);
      case TalismanCategory.relationship:
        return const Color(0xFFFF9500);
      case TalismanCategory.goal:
        return const Color(0xFF50E3C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Talisman Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _categoryColor.withValues(alpha: 0.1),
                  _categoryColor.withValues(alpha: 0.05),
                  TossDesignSystem.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _categoryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _categoryColor.withValues(alpha: 0.15),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _categoryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.talismanDesign.category.emoji,
                        style: DSTypography.labelMedium,
                      ),
                      SizedBox(width: 6),
                      Text(
                        widget.talismanDesign.category.displayName,
                        style: DSTypography.labelSmall.copyWith(
                          color: _categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Talisman Image - 이미지 크기에 맞게 자동 조정
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 280,
                    minWidth: 200,
                  ),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _categoryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _categoryColor.withValues(alpha: 0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: widget.talismanDesign.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.talismanDesign.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderTalisman();
                            },
                          )
                        : _buildPlaceholderTalisman(),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Mantra Text - GPT 스타일 타이핑 효과
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _categoryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: GptStyleTypingText(
                    text: widget.talismanDesign.mantraText,
                    style: DSTypography.bodyMedium.copyWith(
                      color: TossDesignSystem.textPrimaryLight,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    startTyping: _currentTypingSection >= 0,
                    showGhostText: true,
                    onComplete: () {
                      if (mounted) setState(() => _currentTypingSection = 1);
                    },
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0)
            .shimmer(duration: 1500.ms, color: _categoryColor.withValues(alpha: 0.1)),
          
          const SizedBox(height: 32),
          
          // Blessings - GPT 스타일 타이핑 효과
          if (widget.talismanDesign.blessings.isNotEmpty) ...[
            Text(
              '부적의 축복',
              style: DSTypography.headingSmall.copyWith(
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.talismanDesign.blessings.asMap().entries.map((entry) {
              final index = entry.key;
              final blessing = entry.value;
              final blessingIndex = index + 1;  // mantraText가 0번
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 12,
                        color: _categoryColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GptStyleTypingText(
                        text: blessing,
                        style: DSTypography.bodyMedium.copyWith(
                          height: 1.5,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                        startTyping: _currentTypingSection >= blessingIndex,
                        showGhostText: true,
                        onComplete: () {
                          if (mounted && index < widget.talismanDesign.blessings.length - 1) {
                            setState(() => _currentTypingSection = blessingIndex + 1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: UnifiedButton(
                  text: _isSaved ? '저장됨' : '부적 저장하기',
                  onPressed: _isSaved ? null : () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isSaved = true;
                    });
                    widget.onSave?.call();
                  },
                  icon: Icon(
                    _isSaved ? Icons.check : Icons.download,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: UnifiedButton(
                      text: '배경화면 설정',
                      onPressed: widget.onSetWallpaper,
                      style: UnifiedButtonStyle.secondary,
                      icon: const Icon(Icons.wallpaper, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UnifiedButton(
                      text: '공유하기',
                      onPressed: widget.onShare,
                      style: UnifiedButtonStyle.secondary,
                      icon: const Icon(Icons.share, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ).animate(delay: 600.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTalisman() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _categoryColor.withValues(alpha: 0.1),
            _categoryColor.withValues(alpha: 0.05),
            TossDesignSystem.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _categoryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 40,
              color: _categoryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.talismanDesign.category.emoji,
            style: DSTypography.displayLarge,
          ),
          SizedBox(height: 8),
          Text(
            widget.talismanDesign.category.displayName,
            style: DSTypography.labelSmall.copyWith(
              color: _categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}