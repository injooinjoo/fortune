import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../../domain/models/talisman_design.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';

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

class _TalismanResultCardState extends State<TalismanResultCard>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossTheme.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: TossTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '부적이 완성되었어요!',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.success,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Talisman Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _categoryColor.withOpacity(0.1),
                  _categoryColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _categoryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _categoryColor.withOpacity(0.15),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                    color: _categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.talismanDesign.category.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.talismanDesign.category.displayName,
                        style: TossTheme.caption.copyWith(
                          color: _categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Talisman Image
                Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _categoryColor.withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _categoryColor.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: widget.talismanDesign.imageUrl.isNotEmpty
                            ? SvgPicture.asset(
                                widget.talismanDesign.imageUrl,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholderBuilder: (context) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                                  ),
                                ),
                              )
                            : _buildPlaceholderTalisman(),
                      ),
                    ),
                    
                    // Sparkle Effect
                    ...List.generate(6, (index) {
                      return AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          final angle = (index * 60) + (_sparkleController.value * 360);
                          final radius = 110.0;
                          final x = 100 + radius * 0.8 * math.cos(angle * math.pi / 180);
                          final y = 100 + radius * 0.8 * math.sin(angle * math.pi / 180);
                          
                          return Positioned(
                            left: x - 6,
                            top: y - 6,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _categoryColor.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Mantra Text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _categoryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    widget.talismanDesign.mantraText,
                    style: TossTheme.body3.copyWith(
                      color: TossTheme.textBlack,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0)
            .shimmer(duration: 1500.ms, color: _categoryColor.withOpacity(0.1)),
          
          const SizedBox(height: 32),
          
          // Blessings
          if (widget.talismanDesign.blessings.isNotEmpty) ...[
            Text(
              '부적의 축복',
              style: TossTheme.heading3,
            ),
            const SizedBox(height: 16),
            ...widget.talismanDesign.blessings.map((blessing) {
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
                        color: _categoryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 12,
                        color: _categoryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        blessing,
                        style: TossTheme.body3.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 32),
          ],
          
          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TossButton(
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
                    child: TossButton(
                      text: '배경화면 설정',
                      onPressed: widget.onSetWallpaper,
                      style: TossButtonStyle.secondary,
                      icon: const Icon(Icons.wallpaper, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TossButton(
                      text: '공유하기',
                      onPressed: widget.onShare,
                      style: TossButtonStyle.secondary,
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
            _categoryColor.withOpacity(0.1),
            _categoryColor.withOpacity(0.05),
            Colors.white,
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
              color: _categoryColor.withOpacity(0.2),
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
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            widget.talismanDesign.category.displayName,
            style: TossTheme.caption.copyWith(
              color: _categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}